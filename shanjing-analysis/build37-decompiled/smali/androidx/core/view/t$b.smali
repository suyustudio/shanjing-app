.class public final Landroidx/core/view/t$b;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Landroidx/core/view/t;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "b"
.end annotation


# instance fields
.field private final a:Landroidx/core/view/t$f;


# direct methods
.method public constructor <init>()V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    new-instance v0, Landroidx/core/view/t$e;

    invoke-direct {v0}, Landroidx/core/view/t$e;-><init>()V

    :goto_0
    iput-object v0, p0, Landroidx/core/view/t$b;->a:Landroidx/core/view/t$f;

    goto :goto_1

    :cond_0
    const/16 v1, 0x1d

    if-lt v0, v1, :cond_1

    new-instance v0, Landroidx/core/view/t$d;

    invoke-direct {v0}, Landroidx/core/view/t$d;-><init>()V

    goto :goto_0

    :cond_1
    new-instance v0, Landroidx/core/view/t$c;

    invoke-direct {v0}, Landroidx/core/view/t$c;-><init>()V

    goto :goto_0

    :goto_1
    return-void
.end method


# virtual methods
.method public a()Landroidx/core/view/t;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$b;->a:Landroidx/core/view/t$f;

    invoke-virtual {v0}, Landroidx/core/view/t$f;->b()Landroidx/core/view/t;

    move-result-object v0

    return-object v0
.end method

.method public b(Landroidx/core/graphics/a;)Landroidx/core/view/t$b;
    .locals 1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    iget-object v0, p0, Landroidx/core/view/t$b;->a:Landroidx/core/view/t$f;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$f;->d(Landroidx/core/graphics/a;)V

    return-object p0
.end method

.method public c(Landroidx/core/graphics/a;)Landroidx/core/view/t$b;
    .locals 1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    iget-object v0, p0, Landroidx/core/view/t$b;->a:Landroidx/core/view/t$f;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$f;->f(Landroidx/core/graphics/a;)V

    return-object p0
.end method
