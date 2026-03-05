.class public final synthetic Lr/l;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lr/m;

.field public final synthetic e:Lr/k;


# direct methods
.method public synthetic constructor <init>(Lr/m;Lr/k;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr/l;->d:Lr/m;

    iput-object p2, p0, Lr/l;->e:Lr/k;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lr/l;->d:Lr/m;

    iget-object v1, p0, Lr/l;->e:Lr/k;

    invoke-static {v0, v1}, Lr/m;->a(Lr/m;Lr/k;)V

    return-void
.end method
