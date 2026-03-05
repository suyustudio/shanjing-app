.class public Li0/o;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Li0/o$a;,
        Li0/o$b;,
        Li0/o$c;
    }
.end annotation


# static fields
.field private static final b:Li0/o$a;


# instance fields
.field public final a:Lj0/a;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lj0/a<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Li0/o$a;

    invoke-direct {v0}, Li0/o$a;-><init>()V

    sput-object v0, Li0/o;->b:Li0/o$a;

    return-void
.end method

.method public constructor <init>(Lx/a;)V
    .locals 3

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lj0/a;

    sget-object v1, Lj0/f;->a:Lj0/f;

    const-string v2, "flutter/settings"

    invoke-direct {v0, p1, v2, v1}, Lj0/a;-><init>(Lj0/c;Ljava/lang/String;Lj0/i;)V

    iput-object v0, p0, Li0/o;->a:Lj0/a;

    return-void
.end method

.method static synthetic a()Li0/o$a;
    .locals 1

    sget-object v0, Li0/o;->b:Li0/o$a;

    return-object v0
.end method

.method public static b(I)Landroid/util/DisplayMetrics;
    .locals 1

    sget-object v0, Li0/o;->b:Li0/o$a;

    invoke-virtual {v0, p0}, Li0/o$a;->c(I)Li0/o$a$b;

    move-result-object p0

    if-nez p0, :cond_0

    const/4 p0, 0x0

    goto :goto_0

    :cond_0
    invoke-static {p0}, Li0/o$a$b;->a(Li0/o$a$b;)Landroid/util/DisplayMetrics;

    move-result-object p0

    :goto_0
    return-object p0
.end method

.method public static c()Z
    .locals 2
    .annotation build Landroid/annotation/SuppressLint;
        value = {
            "AnnotateVersionCheck"
        }
    .end annotation

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x22

    if-lt v0, v1, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method


# virtual methods
.method public d()Li0/o$b;
    .locals 2

    new-instance v0, Li0/o$b;

    iget-object v1, p0, Li0/o;->a:Lj0/a;

    invoke-direct {v0, v1}, Li0/o$b;-><init>(Lj0/a;)V

    return-object v0
.end method
