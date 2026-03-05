.class Li0/i$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/k$c;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Li0/i;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Li0/i;


# direct methods
.method constructor <init>(Li0/i;)V
    .locals 0

    iput-object p1, p0, Li0/i$a;->a:Li0/i;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public h(Lj0/j;Lj0/k$d;)V
    .locals 0

    const/4 p1, 0x0

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method
